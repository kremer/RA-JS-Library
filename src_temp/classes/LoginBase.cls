public with sharing class LoginBase {
	public LoginBase() {

	}
	public String returnUrl { get { return 'apex/familyfirst#home';} }
	/** This is a hack to determine is the page is using SSL or not.  If CipherSuite is defined that means it is HTTPS **/
    public Boolean hasSSL { get { return ApexPages.currentPage().getHeaders().get('CipherSuite') != null; } }
    
    /** This is used to determine the device type **/
    public String userAgent { get { return ApexPages.currentPage().getHeaders().get('USER-AGENT');  } }
   
    /** This will return which Salesforce Server you are on, example: na8.salesforce.com **/
    public String currentServer { get {return ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To'); } }

    /** Check to see if the page is using HTTPS, if not redirect it back to itself with HTTPS **/
    public PageReference redirect() {
        if (!hasSSL) {
            string host = ApexPages.currentPage().getHeaders().get('host');
            string url = ApexPages.currentPage().getUrl();
            PageReference homePage = new PageReference('https://'+host+url);
            homePage.setRedirect(true);
            return homePage;
        } else {
            return null;    
        } 
    }
}