#!/bin/bash

# 检查是否提供了 commit 评论参数
if [ $# -eq 0 ]; then
    echo "错误：请提供 commit 评论作为参数"
    echo "使用方式：$0 \"你的 commit 消息\""
    exit 1
fi

# 执行 git add .
echo "执行 git add . ..."
git add .
if [ $? -ne 0 ]; then
    echo "git add 失败"
    exit 1
fi

# 执行 git commit -m（使用传入的参数作为消息）
commit_msg="$1"
echo "执行 git commit -m \"$commit_msg\" ..."
git commit -m "$commit_msg"
if [ $? -ne 0 ]; then
    echo "git commit 失败"
    exit 1
fi

# 执行 git push
echo "执行 git push ..."
git push
if [ $? -ne 0 ]; then
    echo "git push 失败"
    exit 1
fi

echo "所有操作完成：add -> commit -> push 成功"