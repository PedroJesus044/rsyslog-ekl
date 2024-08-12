FROM logstash:8.15.0
COPY logstash.conf /usr/share/logstash/pipeline/logstash.conf
CMD ["logstash", "-f", "/usr/share/logstash/pipeline/logstash.conf"]