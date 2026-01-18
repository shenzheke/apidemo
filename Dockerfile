FROM 10.0.0.41/library/python:3.10-slim
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /app

COPY requirements.txt .
#RUN pip install -r requirements.txt
#RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple \
# && pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn \
# && pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir -r requirements.txt \
    --index-url https://mirrors.aliyun.com/pypi/simple/ \
    --trusted-host mirrors.aliyun.com
COPY app.py .

EXPOSE 5000
CMD ["python", "app.py"]

