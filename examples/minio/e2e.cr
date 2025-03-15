require "../../src/awscr-s3"

Log.setup_from_env

# Use the credentials and settings to support minio instance from compose
ENDPOINT = ENV.fetch("S3_ENDPOINT", "http://127.0.0.1:9000")
BUCKET   = ENV.fetch("S3_BUCKET", "storage")
KEY      = ENV.fetch("S3_KEY", "admin")
SECRET   = ENV.fetch("S4_SECRET", "password")

client = Awscr::S3::Client.new(
  region: "unused",
  aws_access_key: KEY,
  aws_secret_key: SECRET,
  endpoint: ENDPOINT
)

# List buckets
buckets = client.list_buckets.map(&.name).join(", ")
puts "1. List buckets: #{buckets}"
puts

# Create a bucket
bucket_name = "e2e-#{UUID.random}"
resp = client.put_bucket(bucket_name)
if resp
  puts "2. Created a new bucket: #{bucket_name}"
else
  puts "ERROR: Could not create a bucket #{bucket_name}: #{resp}"
  exit 1
end
buckets = client.list_buckets.map(&.name).join(", ")
puts "   List buckets: #{buckets}"
puts

# Create a new object
key = "foo"
body = "Content of the Key"
resp = client.put_object(bucket_name, key, body)
puts "3. Created a new object #{key}: #{resp.etag}"

# Get the object by key
resp = client.get_object(bucket_name, key)
puts "4. Get the body of the created object: #{resp.body}"
puts

# Or stream the object (recommended for large objects)
puts "4. Get the body of the created object with streaming:"
client.get_object(bucket_name, key) do |obj|
  IO.copy(obj.body_io, STDOUT) # => myobjectbody
end
puts "\n\n"

# List objects
puts "5. List objects:"
client.list_objects(bucket_name).each do |resp|
  puts resp.contents.map(&.key)
end
puts
