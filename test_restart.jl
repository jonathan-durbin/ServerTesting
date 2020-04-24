using HTTP

function getCurrentCommit(owner, repo)
    headers = Dict(
        "Accept" => "application/vnd.github.VERSION.sha",
        "Connection" => "close"
    )
    try
        resp = HTTP.get("https://api.github.com/repos/$owner/$repo/commits/", headers)
        return resp.body
    catch e
        throw(e)
    end
end

function repoUpdated(sha)
    newsha = getCurrentCommit()
    return sha == newsha ? false : true
end

function main()
    command = `julia $PROGRAM_FILE`
    sha = getCurrentCommit()

    # Check whether github repo has updated
    if !repoUpdated(sha)
        # if not, do work
        println("sleeping...")
        sleep(5)
    else
        # if repo is updated, re-run PROGRAM_FILE
        atexit(() -> run(command))
        exit(0)
    end

end


main()