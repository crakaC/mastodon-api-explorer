require 'pg'
require 'json'

# JSON指定してぶちこむだけ
statuses = JSON.parse(File.read(ARGV[0]))
conn = nil
begin
    conn = PG.connect( dbname: 'chin_count' )
    conn.prepare("insert", "INSERT INTO statuses VALUES($1, $2)")
    statuses.each do |status|
        conn.exec_prepared("insert", [status['id'], status['content']])
    end
rescue => ex
    p ex
    conn.exec("ROLLBACK") if conn
ensure
    conn.close if conn
end