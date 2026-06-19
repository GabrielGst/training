#!/usr/bin/env bash

curl http://localhost:11434/api/chat -d '{
    "model": "llama3.1",
    "messages": [
        {"role": "system", "content": "You are a helpful poet assistant."},
        {"role": "user", "content": "Write a short poem, Shakespear style."}
    ],
    "stream": false
}'