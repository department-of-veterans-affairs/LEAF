<style>
    .body_404 {
        width: 100%;
        height: 100%;
        display: flex;
        justify-content: center;
        align-items: center;
    }

    .wrapper_404 {
        display: flex;
        flex-wrap: wrap;
        justify-content: center;
        align-items: center;
        width: 90%;
        max-width: 900px;
        padding: 50px 0;
        border-radius: 10px;
        word-wrap: break-word;
    }

    .wrapper_404>img {
        width: 50%;
        min-width: 400px;
    }

    .wrapper_404>h1 {
        width: 100%;
        text-align: center;
        font-family: sans-serif;
        font-size: 5.5rem;
        margin: 20px 0 0 0;
    }

    .wrapper_404>h2 {
        width: 100%;
        text-align: center;
        font-family: sans-serif;
        font-size: 2.5rem;
        margin: 0;
    }

    .wrapper_404>h3 {
        width: 100%;
        text-align: center;
        font-family: sans-serif;
        margin: 25px 0 10px 0;
    }

    .wrapper_404>p {
        width: 80%;
        max-width: 660px;
        text-align: center;
        font-family: sans-serif;
        line-height: 1.5rem;
        margin: 30px 0 15px 0;
    }

    .button_wrapper_404 {
        width: 100%;
        text-align: center;
    }

    #button_homepage_404 {
        text-align: center;
        padding: 15px;
        background-color: #0171bd;
        border-radius: 5px;
        font-size: 1.2rem;
        cursor: pointer;
        font-family: sans-serif;
        appearance: none;
        border: none;
        color: #fff;
    }

    #button_homepage_404:hover {
        background-color: #0063a4;
    }

    .wrapper_404>span {
        width: 90%;
        max-width: 900px;
        font-family: sans-serif;
        font-size: 1.2rem;
        color: #de0101;
        text-align: center;
    }
</style>

<div class="body_404">
    <div class="wrapper_404">
        <img src="https://raw.githubusercontent.com/department-of-veterans-affairs/LEAF/7a1adae96eba3e7b21ac26224f25c17b48c6a551/libs/dynicons/svg/LEAF-logo.svg" alt="VA LEAF Logo">

        <h1>404</h1>
        <h2>Page Not Found</h2>
        <h3>The requested URL is:</h3>
        <span id="requestedUrl"></span>
        <p>We apologize, but it appears that the page does not exist. You can navigate to our homepage or double-check if you have entered the correct address.</p>
        <div class="button_wrapper_404">
            <button id="button_homepage_404">Homepage</button>
        </div>
    </div>
</div>


<script>
    // JavaScript to display the requested URL
    var requestedUrl = window.location.href;
    document.getElementById("requestedUrl").textContent = requestedUrl;

    // Define the homepage URL dynamically
    var homepageURL = "/LEAF_Request_Portal/"; // Change this to your actual homepage URL

    // JavaScript to set the address for the button
    var buttonHomepage = document.getElementById("button_homepage_404");
    buttonHomepage.addEventListener("click", function() {
        window.location.href = homepageURL;
    });
</script>

</script>