public class Demo_GoogleAPIController{
    string code;
    string ClientId;
    string Secret;
    string Scope;
    string RedirectURI;
    string token;
    public Integer responseCode{get;set;}
    public String response{get;set;}
    public ResponseClass driveResponse{get;set;}
    public GoogleDriveFileMetadata fileMetadata{get;set;}
    public String selectedFileID {get;set;}
    public FileMetadataClass fileData {get;set;}
    
    public Demo_GoogleAPIController(){
        code = ApexPages.currentPage().getParameters().get('code');
        Google__c google = Google__c.getOrgDefaults();
        ClientId = google.Client_ID__c;
        Secret = google.Secret__c;
        Scope = google.Scope__c;
        RedirectURI = google.Redirect_URI__c;
        driveResponse = new ResponseClass();
        //Intilize GoogleOAuth Class
        GoogleOAuth gOauth = new GoogleOAuth(ClientId, Secret, Scope, RedirectURI);
        GoogleOAuth.AuthResponse responseWrapper = new GoogleOAuth.AuthResponse();
        responseWrapper = gOauth.authenticate(code);
        //system.debug('*****************'+responseWrapper.access_token);
        token = responseWrapper.access_token;
        getInformation();
    }
    
    public void getInformation(){
        system.debug('token-------------'+token);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://www.googleapis.com/drive/v3/files');
        req.setMethod('GET');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setHeader('Authorization','Bearer '+token);
        req.setHeader('Accept','application/json');
        HttpResponse res = h.send(req);
        responseCode = res.getStatusCode();
        //system.debug('$$$$$$$$$$'+res.getBody());
        driveResponse = (ResponseClass)JSON.deserialize(res.getBody(), ResponseClass.class);
        system.debug('driveResponse => '+driveResponse.files);
    }
    
    public void fileMetadata(){
        fileData = null;
        system.debug('selectedFileID '+selectedFileID);
        //https://www.googleapis.com/drive/v3/files/selectedFileID
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://www.googleapis.com/drive/v2/files/'+selectedFileID);
        req.setMethod('GET');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setHeader('Authorization','Bearer '+token);
        req.setHeader('Accept','application/json');
        HttpResponse res = h.send(req);
        responseCode = res.getStatusCode();
        system.debug('res.getBody() '+res.getBody());
        //JSONParser parser = JSON.createParser(res.getBody());
        fileData = (FileMetadataClass)JSON.deserialize(res.getBody(), FileMetadataClass.class);
        
    }
    //Wrapper
    public class Files {
        public String kind {get;set;}
        public String id {get;set;}
        public String name {get;set;}
        public String mimeType {get;set;}
    } 
    
    public class ResponseClass{
        public string kind {get;set;}
        public string nextPageToken;
        public Boolean incompleteSearch;
        public List<Files> files{get;set;}
    }
    
    public class FileMetadataClass {
        public string webContentLink {get;set;}
        public string downloadUrl {get;set;}
        public string embedLink {get;set;}    
    }
    
}
