docker build -t codecentric/elk2 .
docker run -p 5601:5601 -p 9200:9200 -p 5000:5000 -it --name elk2 codecentric/elk2
