
#!/bin/bash

# 1. Variables - Change the bucket name to yours!
BUCKET_NAME="bucket-25126"
LOG_FILE="/var/log/httpd/access_log"
REPORT_FILE="index.html"

# 2. Extract Data using Unix commands
# Count total lines in the log
TOTAL_VISITS=$(wc -l < $LOG_FILE)

# Find 404 errors (Page not found)
ERRORS_404=$(grep " 404 " $LOG_FILE | wc -l)

# Get top 3 most active IP addresses
# Get top 5 IPs and format nicely (IP first, then Count)
TOP_IPS=$(awk '{print $1}' $LOG_FILE | sort | uniq -c | sort -nr | head -n 5 | awk '{ printf "%-15s  [ %s Requests ]\n", $2, $1 }')


# 3. Create the HTML Report (The Dashboard)
# 3. Create the HTML Report (The Dashboard)
cat <<EOF > $REPORT_FILE
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cloud Traffic Monitor</title>
    <style>
        /* Modern Reset & Base Styles */
        body {
            margin: 0;
            padding: 40px 20px;
            font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: #e0e6ed;
            min-height: 100vh;
        }

        /* Container */
        .dashboard {
            max-width: 800px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        /* Header */
        .header {
            text-align: center;
            margin-bottom: 30px;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            padding-bottom: 20px;
        }
        .header h1 {
            margin: 0;
            font-size: 2.2rem;
            background: linear-gradient(90deg, #4facfe 0%, #00f2fe 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .timestamp {
            color: #94a3b8;
            font-size: 0.9rem;
            margin-top: 10px;
        }

        /* Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .card {
            background: rgba(0, 0, 0, 0.2);
            padding: 20px;
            border-radius: 15px;
            text-align: center;
            border: 1px solid rgba(255, 255, 255, 0.05);
            transition: transform 0.2s;
        }
        .card:hover {
            transform: translateY(-5px);
            background: rgba(0, 0, 0, 0.3);
        }

        .card-title {
            font-size: 0.9rem;
            color: #94a3b8;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 10px;
        }
        
        .count {
            font-size: 2.5rem;
            font-weight: bold;
        }
        
        /* Color Coding */
        .blue { color: #4facfe; text-shadow: 0 0 15px rgba(79, 172, 254, 0.3); }
        .red { color: #ff5858; text-shadow: 0 0 15px rgba(255, 88, 88, 0.3); }

        /* Terminal Window for IPs */
        .terminal-window {
            background: #0f172a;
            border-radius: 10px;
            overflow: hidden;
            border: 1px solid #334155;
            box-shadow: inset 0 0 20px rgba(0,0,0,0.5);
        }
        
        .terminal-header {
            background: #1e293b;
            padding: 10px 15px;
            font-size: 0.85rem;
            color: #cbd5e1;
            display: flex;
            align-items: center;
            gap: 8px;
            border-bottom: 1px solid #334155;
        }
        
        .dot { width: 10px; height: 10px; border-radius: 50%; display: inline-block; }
        .red-dot { background: #ff5f56; }
        .yellow-dot { background: #ffbd2e; }
        .green-dot { background: #27c93f; }

        pre {
            margin: 0;
            padding: 20px;
            color: #27c93f;
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 0.95rem;
            line-height: 1.5;
            white-space: pre-wrap;
        }

        /* Mobile Fix */
        @media (max-width: 600px) {
            .stats-grid { grid-template-columns: 1fr; }
            .dashboard { padding: 20px; }
        }
    </style>
</head>
<body>

    <div class="dashboard">
        <div class="header">
            <h1>AWS Cloud Monitor</h1>
            <div class="timestamp">Last Synced: $(date)</div>
        </div>

        <div class="stats-grid">
            <div class="card">
                <div class="card-title">Total Requests</div>
                <div class="count blue">$TOTAL_VISITS</div>
            </div>

            <div class="card">
                <div class="card-title">Security Alerts (404)</div>
                <div class="count red">$ERRORS_404</div>
            </div>
        </div>

        <h3 style="margin-left: 5px; color: #cbd5e1;">Live Traffic Feed (Top IPs)</h3>
        
        <div class="terminal-window">
            <div class="terminal-header">
                <span class="dot red-dot"></span>
                <span class="dot yellow-dot"></span>
                <span class="dot green-dot"></span>
                <span style="margin-left: 10px;">/var/log/httpd/access_log - Watcher</span>
            </div>
            <pre>$TOP_IPS</pre>
        </div>
    </div>

</body>
</html>
EOF
aws s3 cp $REPORT_FILE s3://$BUCKET_NAME/index.html --cache-control "max-age=0, no-cache, no-store, must-revalidate"
