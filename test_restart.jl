using HTTP, JSON

# X-RateLimit-Limit: 60
# X-RateLimit-Remaining: 56
# X-RateLimit-Reset: 1372700873


function getCurrentCommit(owner, repo)
    headers = Dict(
        # "Accept" => "application/vnd.github.VERSION.sha",
        "Connection" => "close"
    )
    try
        resp = HTTP.get("https://api.github.com/repos/$owner/$repo/git/ref/heads/master", headers)
        println("Requests remaining: $(Dict(resp.headers)["X-Ratelimit-Remaining"])")
        respbody = JSON.parse(String(resp.body))
        return respbody["object"]["sha"]
    catch e
        @show resp
        throw(e)
    end
end

function repoUpdated(sha, owner, repo)
    newsha = getCurrentCommit(owner, repo)
    return sha == newsha ? false : true
end

function main()
    command = `julia $PROGRAM_FILE`
    owner = "jonathan-durbin"
    repo = "ServerTesting"
    v = 3
    sha = getCurrentCommit(owner, repo)
    sleep(5)

    while true
        # Check whether github repo has updated
        if !repoUpdated(sha, owner, repo)
            # if not, do work
            println("sleeping... V$v")
            sleep(10)
        else
            # if repo is updated, re-run PROGRAM_FILE
            println("restarting... V$v")
            atexit(() -> run(command))
            exit(0)
        end
    end
end


main()