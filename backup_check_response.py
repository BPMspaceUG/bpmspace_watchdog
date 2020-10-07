# Read result file
with open("/data/result", "r") as f:
    keyword, message, timestamp = f.readlines()

# Generate HTML response
print("Content-Type: text/html\r\n")
print("<html>")
print("<head>")
print("</head>")
print("<body>")
print(f"<h1>{keyword}</h1>")
print(f"<h3>Message: {message}</h3>")
print(f"<h3>Timestamp: {timestamp}</h3>")
print("</body>")
print("</html>")
