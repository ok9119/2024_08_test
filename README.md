***---ЗАДАЧА 2---***

***Docker-образ содержит:***
- samtools v1.20
- htslib v1.20
- bcftools v1.20
- vcftools v0.1.16
- libdeflate:latest
- папку scripts с файлами по задаче 3 (исходный файл с SNP, предобработанный файл, 2 варианта скрипта)
- 
***Для сборки образа:***
docker build . -t <имя_образа>

***Для запуска в интерактивном режиме:***
docker run -it <имя_образа>


