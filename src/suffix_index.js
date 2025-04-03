function handler(event) {
  console.log(event);
  let request = event.request;
  let uri = request.uri;
  const host = request.headers.host.value;

  // Check whether the URI is missing a file name.
  if (uri.endsWith("/")) {
    request.uri += "index.html";
  }
  // Check whether the URI is missing a file extension.
  else if (!uri.includes(".")) {
    request.uri += "/index.html";
  }

  if (host.includes("cloudfront.net")) {
    return {
      statusCode: 403,
      statusDescription: "Forbidden",
      body: {
        encoding: "text",
        data: "<html><head><title>403 Forbidden</title></head><body><center><h1>403 Forbidden</h1></center></body></html>",
      },
    };
  }

  return request;
}
