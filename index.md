## Bright Ground API

Weather forecasts are is primarily found using models run by goverment agencies, but the outputs aern't easy to use or in formats built for web hosting.

To try to address this, I've put together a service that reads weather forecasts and serves it following the [Dark Sky API](https://darksky.net/dev/docs) style. 

### Source Models 

* HRRR
* NAM
* GFS


## Sign Up! 
<div id="api_umbrella_signup">Loading signup form...</div>

<script src="https://brightumbrella2.azurewebsites.net/assets/javascripts/all-3c841d57.js"></script>
<script src="https://code.jquery.com/jquery-1.10.2.js"></script><title></title>
<script>
 
   /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
   var apiUmbrellaSignupOptions = {
     // Pick a short, unique name to identify your site, like 'gsa-auctions'
     // in this example.
     registrationSource: 'web',

     // Enter the API key you signed up for and specially configured for this
     // API key signup embed form.
     apiKey: 'fy23AoKihBQLW6YzNbEA4QSVkDAzyeYXarqpGcii',

     // Provide a URL or e-mail address to be used for customer support.
     //
     // The format for e-mail addresses can be given as either
     // 'example@example.com' or 'mailto:example@example.com'.
     contactUrl: 'https://brightground.digital/contact',

     // Provide the name of your developer site. This will appear in the
     // subject of the welcome e-mail as "Your {{siteName}} API key".
     siteName: 'Bright Ground API',

     // Provide a sender name for who the welcome email appears from. The
     // actual address will be "noreply@api.data.gov", but this will
     // change the name of the displayed sender in this fashion:
     // "{{emailFromName}} <noreply@api.data.gov>".
     emailFromName: 'noreply@brightground.digital',

     // Provide an example URL you want to show to users after they signup.
     // This can be any API endpoint on your server, and you can use the
     // special {{api_key}} variable to automatically substitute in the API
     // key the user just signed up for.
     exampleApiUrl: 'https://api.data.gov/gsa/auctions?api_key={{api_key}}&format=JSON',

     // OPTIONAL: Provide extra content to display on the signup confirmation
     // page. This will be displayed below the user's API key and the example
     // API URL are shown. HTML is allowed. Defaults to ""
     signupConfirmationMessage: 'Success!',

     // OPTIONAL: Set to true to verify the user's e-mail address by only
     // sending them their API key via e-mail, and not displaying it on the
     // signup confirmation web page. Defaults to false.
     verifyEmail: true,

     // OPTIONAL: Set to false to disable sending a welcome e-mail to the
     // user after signing up. Defaults to true.
     // sendWelcomeEmail: false,

     // OPTIONAL: Provide an extra input field to ask for the user's website.
     // Defaults to false.
     // websiteInput: true,

     // OPTIONAL: Provide an extra checkbox asking the user to agree to terms
     // and conditions before signing up. Defaults to false.
     termsCheckbox: true,

     // OPTIONAL: If the terms & conditions checkbox is enabled, link to this
     // URL for your API's terms & conditions. Defaults to "".
     termsUrl: "https://brightground.digital/api-terms/",
   };

   /* * * DON'T EDIT BELOW THIS LINE * * */
   (function() {
     var apiUmbrella = document.createElement('script'); apiUmbrella.type = 'text/javascript'; apiUmbrella.async = true;
     apiUmbrella.src = 'https://brightumbrella2.azurewebsites.net/assets/javascripts/signup_embed.js';
     (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(apiUmbrella);
   })();
</script>