# Read from the file $1 and output the word frequency list to stdout.

cat $1 | tr  -s ' ' '\n' | awk '{ print toupper($1) }' | sort | uniq -c | sort  -r| awk '{print $2, $1}'


#tr -s: truncate the string with target string, but only remaining one instance (e.g. multiple whitespaces)

#awk print the uppercase version of the first argument

#sort: To make the same string successive so that uniq could count the same string fully and correctly.

#uniq -c: uniq is used to filter out the repeated lines which are successive, -c means counting

#sort -r: -r means sorting in descending order

#awk '{ print $2, $1 }': To format the output, see https://linux.cn/article-3945-1.html

