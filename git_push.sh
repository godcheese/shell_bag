#!/usr/bin/env bash
echo "author godcheese [godcheese@outlook.com]"
echo "Add file..."
git add -A
echo -n "Submit remark...Please input anything(Initial commit):"
read REMARK
if [[ ! -n "$REMARK" ]];then
    REMARK="Initial commit"
fi
git commit -m "$REMARK"
echo "Submit code..."
git push origin master
echo "Submit complete,close..."
