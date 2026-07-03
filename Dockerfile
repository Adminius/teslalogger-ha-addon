FROM bassmaster187/teslalogger:latest

RUN apt-get update && apt-get install -y curl jq

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 5010

CMD ["/run.sh"]
