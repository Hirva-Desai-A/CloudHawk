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
   git clone [https://github.com/Hirva-Desai-A/CloudHawk.git](https://github.com/Hirva-Desai-A/CloudHawk.git)
   cd CloudHawk
