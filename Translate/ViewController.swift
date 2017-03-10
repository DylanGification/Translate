import UIKit
import NVActivityIndicatorView

class ViewController: UIViewController, UITextViewDelegate, NVActivityIndicatorViewable {
    
    @IBOutlet weak var textToTranslate: UITextView!
    @IBOutlet weak var translatedText: UITextView!
    
    @IBOutlet weak var enButton: UIButton!
    @IBOutlet weak var frButton: UIButton!
    @IBOutlet weak var deButton: UIButton!
    @IBOutlet weak var esButton: UIButton!
    @IBOutlet weak var enTransButton: UIButton!
    @IBOutlet weak var frTransButton: UIButton!
    @IBOutlet weak var deTransButton: UIButton!
    @IBOutlet weak var esTransButton: UIButton!
    
    var currTranslateFrom = "en"
    var currTranslateTo = "fr"
    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textToTranslate.delegate = self
        enButton.alpha = 1.0
        frButton.alpha = 0.3
        deButton.alpha = 0.3
        esButton.alpha = 0.3
        
        enTransButton.alpha = 0.3
        frTransButton.alpha = 1.0
        deTransButton.alpha = 0.3
        esTransButton.alpha = 0.3
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_: Set<UITouch>, with: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(textToTranslate.text.contains("<")){
            textToTranslate.text = ""
        }
    }
    
    @IBAction func swapText(_ sender: UIButton) {
        let text = textToTranslate.text
        textToTranslate.text = translatedText.text
        translatedText.text = text
        let lang = currTranslateFrom
        currTranslateFrom = currTranslateTo
        currTranslateTo = lang
        selectLanguage(currTranslateFrom as AnyObject)
        selectTranslation(currTranslateTo as AnyObject)
    }
    
    @IBAction func selectLanguage(_ sender: AnyObject) {
        
        enButton.alpha = 0.4
        frButton.alpha = 0.4
        deButton.alpha = 0.4
        esButton.alpha = 0.4
        if(sender === frButton)
        {
            currTranslateFrom = "fr"
            frButton.alpha = 1
        }
        else if (sender === deButton)
        {
            currTranslateFrom = "de"
            deButton.alpha = 1
        }
        else if (sender === esButton)
        {
            currTranslateFrom = "es"
            esButton.alpha = 1
        }
        else
        {
            currTranslateFrom = "en"
            enButton.alpha = 1
        }
    }
    
    @IBAction func selectTranslation(_ sender: AnyObject) {
        enTransButton.alpha = 0.3
        frTransButton.alpha = 0.3
        deTransButton.alpha = 0.3
        esTransButton.alpha = 0.3
        if(sender === frTransButton)
        {
            currTranslateTo = "fr"
            frTransButton.alpha = 1
        }
        else if (sender === deTransButton)
        {
            currTranslateTo = "de"
            deTransButton.alpha = 1
        }
        else if (sender === esTransButton)
        {
            currTranslateTo = "es"
            esTransButton.alpha = 1
        }
        else
        {
            currTranslateTo = "en"
            enTransButton.alpha = 1
        }
    }
    
    @IBAction func translate(_ sender: AnyObject) {
        if (currTranslateFrom == currTranslateTo)
        {
            let alert = UIAlertController(title: "Alert", message: "Languages cannot be the same.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            let str = textToTranslate.text
            let escapedStr = str?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            let langStr = (currTranslateFrom + "|" + currTranslateTo).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            let urlStr:String = ("https://api.mymemory.translated.net/get?q="+escapedStr!+"&langpair="+langStr!)
            let url = URL(string: urlStr)
            let request = URLRequest(url: url!)
            
            let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            let activityIndicatorView = NVActivityIndicatorView(frame: frame, type: .pacman, color: UIColor.blue)
            activityIndicatorView.center = view.center
            view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            
            var result = "<Translation Error>"
            let task = defaultSession.dataTask(with: request)
            {
                (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse
                {
                    if(httpResponse.statusCode == 200)
                    {
                        let jsonDict: NSDictionary!=(try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
                        if(jsonDict.value(forKey: "responseStatus") as! NSNumber == 200)
                        {
                            let responseData: NSDictionary = jsonDict.object(forKey: "responseData") as! NSDictionary
                            result = responseData.object(forKey: "translatedText") as! String
                        }
                    }
                    DispatchQueue.main.sync()
                        {
                            activityIndicatorView.stopAnimating()
                            self.translatedText.text = result
                    }
                }
            }
            task.resume()
        }
    }
}
