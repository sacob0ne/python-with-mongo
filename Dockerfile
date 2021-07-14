FROM python:3.8.5

RUN mkdir /src
COPY src /src

WORKDIR /src

COPY requirements.txt /src

RUN pip install -r requirements.txt

EXPOSE 5000

CMD ["python" , "/src/app.py"]
