//
//  ViewController.swift
//  SleepingInTheLibrary
//
//  Created by Horacio A Sanchez
//  Copyright © Sanchez Inc. All rights reserved.
//

import UIKit

// MARK: - ViewController: UIViewController

class ViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var grabImageButton: UIButton!
    var weblink: String = "Original"
    
    //Set up 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: Actions
    
    @IBAction func grabNewImage(_ sender: AnyObject) {
        
        getImageFromFlickr()
        //setUIEnabled(false)
        
    }
    
    // MARK: Configure UI
    
    private func setUIEnabled(_ enabled: Bool) {
        photoTitleLabel.isEnabled = enabled
        grabImageButton.isEnabled = enabled
        
        if enabled {
            grabImageButton.alpha = 1.0
        } else {
            grabImageButton.alpha = 0.5
        }
    }
    
    // MARK: Make Network Request
    
    
        
        // TODO: Write the network code here!
        
        //----------------------------------------------------------------------------------------
        //
        // 1) URLSessionTask has three main methods
        //      i) URLSession.shared.dataTask - Into memory as Data
        //      ii) URLSession.shared.downloadTask - Performs downloads
        //      iii) URLSession.shared.uploadTask - Performs uploadas
        //
        // 2) dataTask(with: URLRequest: completionHandler(DATA?, RESPONSE?, ERROR?) -> Void)
        //      * data - The data returned by the server.
        //
        //      * response - An object that provides response metadata, such as HTTP headers
        //        and status code. If you are making an HTTP or HTTPS request, the returned
        //        object is actually an HTTPURLResponse object.
        //
        //      * error - An error object that indicates why the request failed, or nil if the
        //        request was successful.
        //
        // 3) performUIUpdatesOnMain(updates: () -> Void)
        //      * Call this "blackbox function inside the completion handler to update the
        //        screen on our viewer
        //
        // 4) JSONSerialization.jsonObject will help us convert the raw jason data
        //    to a foundation object from which we can extract the data we want. This is known as
        //    parsing data and can be done in these steps:
        //
        //          i) Get raw JSON data
        //          ii) Parse the JSON data into a Foundation object
        //          iii) Grab the data from the foundation object.
        //
        // 5) The "do catch" block implies that the serialization method could trhow
        //    an error. So "do try" this method and if an error is trhown, the "catch"
        //    it and handle it with our erro function!
        //----------------------------------------------------------------------------------------
        

        
        //let url = URL(string: "\(Constants.Flickr.APIBaseURL)?\(Constants.FlickrParameterKeys.Method)=\(Constants.FlickrParameterValues.GalleryPhotosMethod)&\(Constants.FlickrParameterKeys.APIKey)=\(Constants.FlickrParameterValues.APIKey)&\(Constants.FlickrParameterKeys.Extras)=\(Constants.FlickrParameterValues.MediumURL)&\(Constants.FlickrParameterKeys.Format)=\(Constants.FlickrParameterValues.ResponseFormat)&\(Constants.FlickrParameterKeys.NoJSONCallback)=\(Constants.FlickrParameterValues.DisableJSONCallback)")!
        
    private func getImageFromFlickr(){
        
        
        let  url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.galleries.getPhotos&api_key=6e8d70d789e1fad1c4063c8622e135fd&gallery_id=5704-72157622566655097&extras=url_m&format=json&nojsoncallback=1&auth_token=72157678643139003-340493a2f1774755&api_sig=c2c9c0ff3f2bcadf723a6f94ca3e3cd4")
        let request = URLRequest(url: url!)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            //This function handles the error trhown by the method called and re-enable UI
            func displayError(error: String){
                print(error)
                print("URL at time of error: \(url)")
                performUIUpdatesOnMain{
                    self.setUIEnabled(true)
                }
            }
            
            //GUARD: Was there an error?
            guard (error == nil) else{
                displayError(error: "There was an error with your request: \(error)")
                return
            }
            
            //GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                displayError(error: "Your request returned a status code other than 2XX!")
                return
            }
            
            //GUARD: Was there any data returned?
            guard let data =  data else{
                displayError(error: "No data was returned by the request!")
                return
            }
            
            //Parse data
            let parsedResult: AnyObject!
            do{
                // Convert from raw JASON to Foundation Object data
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject!
            }catch{
                //Handle error if trhown
                displayError(error: "Could not parse the data as JSON: \(data)")
                return
            }
            
            //GUARD: Did Flickr returned an error? (stat != ok)?
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else{
                displayError(error: "Flickr API returned an error. See error code message in \(parsedResult)")
                return
            }
            
            //GUARD: Are "photos" and "photo" jeys in our result?
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else{
                displayError(error: "Cannot find keys")
                return
            }
            
            //Select a random photo
            let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
            let photoDictionary = photoArray[randomPhotoIndex] as [String:AnyObject]
            let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
            
            //Does your photo has a key for 'url_m'?
            guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else{
                displayError(error: "Cannot find url for current photo")
                return
            }
            
            //Doing a nested URLSession to retrieve the image from the url data extracted in the parent session
            let imageUrl = URL(string: imageUrlString)
            let umageUrlRequest = URLRequest(url: imageUrl!)
            
            let task2 = URLSession.shared.dataTask(with: umageUrlRequest, completionHandler: { (data2, response2, error2) in
                if error2 == nil{
                    let donwloadedImage = UIImage(data: data2!)
                    performUIUpdatesOnMain{
                        //Update the imageView to display our image
                        self.photoImageView.image = donwloadedImage
                    }
                    
                    print("Completion handler finished")
                }
            
                // Remember to resume the task to that it takes effect
                
            })//End of task2
            
            task2.resume()
        }//end of task
        
        task.resume()
    }
    
}

