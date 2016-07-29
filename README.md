# Spark for Data Science

A `rocker/r-base:latest` based [Spark](http://apache.apache.org) and [Zeppelin](http://zeppelin.apache.org) Docker container.

This image contains:

- [Spark 2.0.0](http://spark.apache.org/docs/2.0.0) and [Hadoop 2.7](http://hadoop.apache.org)
- [PySpark](http://spark.apache.org/docs/2.0.0/api/python) support with [Python 3.5](https://docs.python.org/3.5), [NumPy](http://www.numpy.org), [PandaSQL](https://github.com/yhat/pandasql), [SciPy](https://www.scipy.org/scipylib/index.html) and [scikit-learn](http://scikit-learn.org/)
- Some interpreters out-of-the-box. If your favorite interpreter isn't included, consider [adding it with the api](http://zeppelin.apache.org/docs/0.7.0-SNAPSHOT/manual/dynamicinterpreterload.html).
  - spark
  - shell
  - angular
  - markdown
  - postgresql
  - jdbc
  - python
  - hbase
  - elasticsearch

## simple usage

To start Zeppelin pull the `latest` image and run the container (adding a folder):

```
docker pull josepcurto/sparkzeppelin
docker run --rm --name zeppelin -p 8080:8080 -v /Users/josepcurto/Downloads/zeppelin/datos:/usr/zeppelin/data josepcurto/sparkds
```

Zeppelin will be running at `http://${YOUR_DOCKER_HOST}:8080`.

## build

To build your own container download the docker file and execute:

```
docker build -t my_user/my_sparkds .
```

And then you can push this repository to the registry designated by its name or tag.

```
$ docker push my_user/my_sparkds
```

The image will then be uploaded and available for use by your team-mates and/or the community.

## license

MIT