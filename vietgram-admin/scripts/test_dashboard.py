import requests

session = requests.Session()

# Giả lập thao tác đăng nhập
login_url = "http://localhost:8888/login"
response = session.get(login_url)

# Cần trích xuất CSRF token nếu Spring Security mặc định bật
# Nhưng Spring Security config của chúng ta có the CSRF token. 
# Thử cách login trực tiếp nếu tắt config hoặc trích xuất CSRF
# Ở đây ta sẽ trích CSRF token bằng regex từ login page
import re
token_match = re.search(r'name="_csrf"\s+value="([^"]+)"', response.text)
csrf_token = token_match.group(1) if token_match else ''

login_data = {
    'username': 'admin@vneg.vn',
    'password': 'Admin@123',
    '_csrf': csrf_token
}

# Post login
login_post = session.post(login_url, data=login_data, allow_redirects=False)

if login_post.status_code == 302:
    print("Login success (redirecting to:", login_post.headers.get('Location'), ")")
    dashboard_res = session.get("http://localhost:8888/dashboard")
    print("Dashboard Status Code:", dashboard_res.status_code)
    
    # In ra đoạn đầu của HTML thay vì toàn bộ nếu success
    if dashboard_res.status_code == 500:
        print("ERROR! Content:")
        print(dashboard_res.text[:1000])
    elif dashboard_res.status_code == 200:
        print("DASHBOARD SUCCESSFUL!")
        print(f"Title: {re.search(r'<title>(.*?)</title>', dashboard_res.text, re.IGNORECASE).group(1)}")
else:
    print("Login Failed. Status Code:", login_post.status_code)
    print("Response headers:", login_post.headers)
