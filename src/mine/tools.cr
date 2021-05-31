def capture(cmd, params)
    process = Process.new(cmd, params,
        output: Process::Redirect::Pipe,
        error: Process::Redirect::Pipe,
        )

    output = process.output.gets_to_end
    error  = process.error.gets_to_end

    res = process.wait

    return output, error, res.exit_status
end

def read_config : Tuple(String, String)
    config_file = "config.txt"
    line = File.read_lines(config_file).first
    username, token = line.split(":")
    return username, token
end
