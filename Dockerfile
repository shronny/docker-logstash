FROM logstash:5.6.5

LABEL Description="kafka spliter configuration"

# install plugin dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
		apt-transport-https \
    		curl \
		vim \
		less \
		&& rm -rf /var/lib/apt/lists/*

#FFU
ADD ./src/ /run/
RUN chmod +x -R /run/

COPY ./conf.d/splitter.conf /etc/logstash/conf.d/splitter.conf

VOLUME /etc/logstash/conf.d

EXPOSE 5000

ENV ORDERS_KAFKA_HOST="34.248.173.194" \
    SPLIT_KAFKA_HOST="34.248.173.194" \
    KAFKA_PORT="9092" \
    HEAP_SIZE="512m" \
    GRAPHITE="graphiteServer"

ENTRYPOINT ["/run/entrypoint.sh"]
CMD ["logstash", "-f /etc/logstash/conf.d/splitter.conf", "--config.reload.automatic", "--debug"]
