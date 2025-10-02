import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface S3UploadRequest {
  fileName: string;
  contentType: string;
  fileSize: number;
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Create a Supabase client with the Auth context of the logged in user.
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    // Get the session or user object
    const { data: { user } } = await supabaseClient.auth.getUser()

    if (!user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { 
          status: 401, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    const { fileName, contentType, fileSize }: S3UploadRequest = await req.json()

    // AWS S3 configuration from environment variables
    const AWS_ACCESS_KEY = Deno.env.get('AWS_ACCESS_KEY')
    const AWS_SECRET_KEY = Deno.env.get('AWS_SECRET_KEY')
    const AWS_BUCKET_NAME = Deno.env.get('AWS_BUCKET_NAME')
    const AWS_REGION = Deno.env.get('AWS_REGION') || 'us-east-1'

    if (!AWS_ACCESS_KEY || !AWS_SECRET_KEY || !AWS_BUCKET_NAME) {
      return new Response(
        JSON.stringify({ error: 'AWS configuration missing' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Generate a unique file path
    const timestamp = Date.now()
    const uniqueFileName = `${user.id}/${timestamp}_${fileName}`

    // Generate presigned URL for S3 upload
    const presignedUrl = await generatePresignedUrl({
      accessKey: AWS_ACCESS_KEY,
      secretKey: AWS_SECRET_KEY,
      bucketName: AWS_BUCKET_NAME,
      region: AWS_REGION,
      key: uniqueFileName,
      contentType,
      expiresIn: 3600, // 1 hour
    })

    // The public URL where the file will be accessible after upload
    const publicUrl = `https://${AWS_BUCKET_NAME}.s3.${AWS_REGION}.amazonaws.com/${uniqueFileName}`

    return new Response(
      JSON.stringify({
        presignedUrl,
        publicUrl,
        key: uniqueFileName,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )

  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

async function generatePresignedUrl({
  accessKey,
  secretKey,
  bucketName,
  region,
  key,
  contentType,
  expiresIn = 3600,
}: {
  accessKey: string;
  secretKey: string;
  bucketName: string;
  region: string;
  key: string;
  contentType: string;
  expiresIn?: number;
}) {
  const encoder = new TextEncoder()
  
  // Create the canonical request
  const method = 'PUT'
  const uri = `/${key}`
  const queryString = ''
  const headers = `host:${bucketName}.s3.${region}.amazonaws.com\nx-amz-content-sha256:UNSIGNED-PAYLOAD`
  const signedHeaders = 'host;x-amz-content-sha256'
  const payloadHash = 'UNSIGNED-PAYLOAD'
  
  const canonicalRequest = `${method}\n${uri}\n${queryString}\n${headers}\n\n${signedHeaders}\n${payloadHash}`
  
  // Create the string to sign
  const algorithm = 'AWS4-HMAC-SHA256'
  const timestamp = new Date().toISOString().replace(/[:\-]|\.\d{3}/g, '')
  const date = timestamp.substr(0, 8)
  const credentialScope = `${date}/${region}/s3/aws4_request`
  const stringToSign = `${algorithm}\n${timestamp}\n${credentialScope}\n${await sha256(canonicalRequest)}`
  
  // Calculate the signature
  const dateKey = await hmacSha256(encoder.encode(`AWS4${secretKey}`), date)
  const dateRegionKey = await hmacSha256(dateKey, region)
  const dateRegionServiceKey = await hmacSha256(dateRegionKey, 's3')
  const signingKey = await hmacSha256(dateRegionServiceKey, 'aws4_request')
  const signature = await hmacSha256(signingKey, stringToSign)
  
  // Build the presigned URL
  const credential = `${accessKey}/${credentialScope}`
  const signatureHex = Array.from(new Uint8Array(signature))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('')
  
  const params = new URLSearchParams({
    'X-Amz-Algorithm': algorithm,
    'X-Amz-Credential': credential,
    'X-Amz-Date': timestamp,
    'X-Amz-Expires': expiresIn.toString(),
    'X-Amz-SignedHeaders': signedHeaders,
    'X-Amz-Signature': signatureHex,
  })
  
  return `https://${bucketName}.s3.${region}.amazonaws.com${uri}?${params.toString()}`
}

async function sha256(message: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(message)
  const hashBuffer = await crypto.subtle.digest('SHA-256', data)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('')
}

async function hmacSha256(key: Uint8Array | ArrayBuffer, message: string): Promise<ArrayBuffer> {
  const encoder = new TextEncoder()
  const cryptoKey = await crypto.subtle.importKey(
    'raw',
    key,
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  )
  return await crypto.subtle.sign('HMAC', cryptoKey, encoder.encode(message))
}