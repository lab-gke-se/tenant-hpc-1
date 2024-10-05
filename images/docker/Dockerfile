FROM python:3

WORKDIR /
COPY ./src/worker/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY ./src/worker/main.py .

CMD python3 ./main.py