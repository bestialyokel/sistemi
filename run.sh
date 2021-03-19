
echo "" > result;

for i in {1..4000}; do
    for j in {1..4000}; do
        escript bst.erl ${i} ${j} >> result; echo -n "," >> result;
    done
    printf "\n" >> result;
done