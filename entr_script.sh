while true; do
	ls -d /home/{{USER}}/consul_service/*.json | entr -d consul reload
done
