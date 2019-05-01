printf "\nWhat is the IP address or Name of the Domain or SMS you want to check?\n"
read DOMAIN

printf "\nDisplaying Tags\n"
mgmt_cli -r true show tags limit 500 --format json | jq -r '.objects[] | .name'

printf "\nWhat TAG would you like to remove?\n"
read TAG

printf "\nDetermining Number of Objects\n"
total=$(mgmt_cli -r true -d $DOMAIN show objects --format json |jq '.total')
printf "There are $total objects\n"

printf "\nGenerting Script to remove $TAG tag\n"
for I in $(seq 0 500 $total)
do
mgmt_cli -r true show objects offset $I limit 500 details-level full filter "$TAG" --format json | jq --raw-output --arg Q "'" --arg TAG "$TAG" '.objects[] | select(.tags[].name==$TAG) | "mgmt_cli -s id.txt set " + .type + " name " + $Q + .name + $Q + " tags.remove " + $Q + .tags[].name + $Q' >>tag_remove_$TAG.txt
done

chmod +x tag_remove_$TAG.txt
sed -i '1s/^/mgmt_cli -r true login > id.txt\n/' tag_remove_$TAG.txt
echo "mgmt_cli -s id.txt publish" >> tag_remove_$TAG.txt
echo "mgmt_cli -s id.txt logout" >> tag_remove_$TAG.txt

printf "\nYou can execute file tag_remove_$TAG.txt to remove tags\n"
