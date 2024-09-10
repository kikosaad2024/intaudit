import vsthrottle;

sub vcl_recv {

        # Varnish will set client.identity for you based on client IP.

        if ( req.url !~ "^[^?]*\.(7z|avi|bmp|bz2|css|csv|doc|docx|eot|flac|flv|gif|gz|ico|jpeg|html|jpg|js|less|mka|mkv|mov|mp3|mp4|mpeg|mpg|odt|ogg|ogm|opus|otf|pdf|png|ppt|pptx|rar|rtf|svg|svgz|swf|tar|tbz|tgz|ttf|txt|txz|wav|webm|webp|woff|woff2|xls|xlsx|xml|xz|zip)(\?.*)?$" && vsthrottle.is_denied(req.http.X-Client-IP, 10, 15s, 123s)) {
                # Client has exceeded 50 reqs per 15s.
                # When this happens, block altogether for the next 123s.
                return (synth(429, "Too Many Requests"));
        }

        # Only allow a few POST/PUTs per client.
        if (req.method == "POST" || req.method == "PUT") {
                if (vsthrottle.is_denied("rw" + req.http.X-Client-IP, 3, 10s, 123s)) {
                        return (synth(429, "Too Many Requests"));
                }
        }
        set req.backend_hint = main.backend();
}
