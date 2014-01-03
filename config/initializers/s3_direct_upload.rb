S3DirectUpload.config do |c|
  c.access_key_id = "AKIAJVI4CATVGSWYERMA"       # your access key id
  c.secret_access_key = "Pq1hQGjmBCd9B7OJdb3O53FlUUxSrIDgYYyCslPJ"   # your secret access key
  c.bucket = "dota2rails.user.replays"              # your bucket name
  c.region = nil             # region prefix of your bucket url (optional), eg. "s3-eu-west-1"
  c.url = nil                # S3 API endpoint (optional), eg. "https://#{c.bucket}.s3.amazonaws.com/"
end
