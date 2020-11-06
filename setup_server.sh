  sudo openssl genrsa -out ~/.ssh/localhost.key 2048

sudo openssl req -new -x509 -key ~/.ssh/localhost.key -out ~/.ssh/localhost.crt -days 3650 -subj /CN=localhost

sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ~/.ssh/localhost.crt

npm install -g http-server


  http-server --ssl --cert ~/.ssh/localhost.crt --key ~/.ssh/localhost.key -p10980