redis = Redis.new
namepsace = "boom_bam_splash:#{Rails.env}"
$redis = Redis::Namespace.new(namepsace, :redis => redis)
