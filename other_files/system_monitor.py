# code from
# https://dev.to/vachhanirishi/automating-cpu-and-memory-utilization-logging-with-cron-jobs-on-windows-and-linux-2phl

import psutil
import datetime
import os

def log_system_utilization():
    today = datetime.datetime.now().strftime("%Y-%m-%d")
    log_dir = "logs"
    os.makedirs(log_dir, exist_ok=True)
    log_file = os.path.join(log_dir, f"cpu_memory_log_{today}.txt")

    with open(log_file, "a") as f:
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        cpu_usage = psutil.cpu_percent(interval=1)
        memory_usage = psutil.virtual_memory().percent
        # if the memory of the docker reaches or goes beyond 70% 
        # then it gets written down
        if (memory_usage >= 70):
            log_entry = f"{timestamp} - CPU Usage: {cpu_usage}% | Memory Usage: {memory_usage}%\n"
            f.write(log_entry)

if __name__ == "__main__":
    log_system_utilization()

