#!/bin/bash
# Install CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/bin/config.json <<'EOF'
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "metrics": {
    "metrics_collected": {
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      },
      "swap": {
        "measurement": ["swap_used_percent"],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": ["used_percent"],
        "metrics_collection_interval": 60,
        "resources": ["/"]
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/${environment}/var/log/messages",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/application.log",
            "log_group_name": "/${environment}/application",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF

# Start CloudWatch agent
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

# Install application dependencies
yum update -y
yum install -y nodejs npm

# Set up application directory
mkdir -p /opt/application
cd /opt/application

# Set up health check endpoint
cat > /opt/application/server.js <<'EOF'
const http = require('http');

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200);
    res.end('OK');
    return;
  }
  
  res.writeHead(200);
  res.end('Hello from ${environment} in ${region}!');
});

server.listen(80, () => {
  console.log('Server running on port 80');
});
EOF

# Start application
npm init -y
node server.js &