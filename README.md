
# CloudHawk

CloudHawk is a lightweight, serverless surveillance system that transforms raw Linux server logs into a real-time, dark-mode cybersecurity dashboard hosted on AWS S3. It combines the power of native Linux processing tools with the scalability of the AWS Cloud.

![Dashboard Preview](dashboard-preview.png)

## Features

- **Real-Time Monitoring**: Live dashboard updates every second to show active traffic.
- **Log Analysis**: Automatically parses raw Apache logs for IP addresses and HTTP status codes.
- **Dark Mode UI**: Generates a professional, cyber-themed visual interface.
- **Automated Deployment**: Seamlessly syncs reports to a public AWS S3 bucket.

## Prerequisites

CloudHawk relies on the following powerful tools:
- `AWS CLI`: For secure S3 uploads.
- `Apache HTTPD`: As the web server and log source.
- `Bash`: For the core automation logic.
- `awk` / `grep`: For high-speed text processing and pattern matching.

## Installation

### AWS EC2 Setup (Recommended)

CloudHawk is optimized for Amazon Linux 2023.

1. Clone the repository:
   ```bash
   git clone https://github.com/Hirva-Desai-A/CloudHawk.git
   cd CloudHawk

```

2. Install dependencies:
```bash
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd

```


3. Configure Permissions:
```bash
chmod +x analyzer.sh dashboard_looper.sh
sudo chmod 755 /var/log/httpd
sudo chmod 644 /var/log/httpd/access_log

```



### Manual Configuration

If you have not set up your AWS credentials yet:

1. Configure the AWS CLI:
```bash
aws configure

```


*Enter your Access Key ID, Secret Access Key, and Region (us-east-1).*
2. Update the Bucket Name:
Edit the script to point to your specific S3 bucket.
```bash
nano analyzer.sh
# Update BUCKET_NAME="your-unique-bucket-name"

```



## Usage

Simply run the automation script in your terminal:

```bash
./dashboard_looper.sh

```

1. The script will initialize and start parsing logs immediately.
2. Visit your **S3 Static Website URL** in your browser.
3. The dashboard will automatically refresh to show:
* **Total Requests**: Visitor count.
* **Security Alerts**: 404/Error count.
* **Top IPs**: A list of the most active visitors.


4. Press `Ctrl+C` in the terminal to stop the monitor.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
```

```
