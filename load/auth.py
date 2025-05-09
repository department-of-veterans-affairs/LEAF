import requests

def authenticate(username, password):
    login_url = "https://auth.leaf-preprod.va.gov/index.php"
    payload = {"username": username, "password": password}
    response = requests.post(login_url, data=payload)
    
    if response.status_code == 200:
        # Get the Set-Cookie header value
        cookie_header = response.headers.get("Set-Cookie")
        
        # Extract the cookie value (assuming it's in the format "PHPSESSID=...")
        cookie_value = cookie_header.split("=")[1]
        
        return cookie_value
    
    print(f"Authentication failed: {response.text}")
    return None