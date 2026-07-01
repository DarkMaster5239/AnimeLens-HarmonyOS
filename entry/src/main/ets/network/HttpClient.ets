import { http } from '@kit.NetworkKit'

export class HttpClient {

  /**
   * GET 请求
   */
  static async get<T>(url: string): Promise<T> {
    const client = http.createHttp()

    try {
      const response = await client.request(url, {
        method: http.RequestMethod.GET,
        readTimeout: 15000,
        connectTimeout: 10000,
        header: {
          'Accept': 'application/json'
        }
      })

      if (response.responseCode !== 200) {
        throw new Error(`HTTP ${response.responseCode}`)
      }

      return JSON.parse(response.result as string) as T

    } catch (err) {
      console.error("Http GET Error:", JSON.stringify(err))
      // 检查 err 是否为 Error 的实例
      if (err instanceof Error) {
        throw err
      } else {
        throw new Error(String(err))
      }
    } finally {
      client.destroy()
    }
  }

  /**
   * POST 请求（后续搜图接口会用到）
   */
  static async post<T>(
    url: string,
    body: Object
  ): Promise<T> {

    const client = http.createHttp()

    try {
      const response = await client.request(url, {
        method: http.RequestMethod.POST,
        readTimeout: 15000,
        connectTimeout: 10000,
        header: {
          "Content-Type": "application/json"
        },
        extraData: JSON.stringify(body)
      })

      if (response.responseCode !== 200) {
        throw new Error(`HTTP ${response.responseCode}`)
      }

      return JSON.parse(response.result as string) as T

    } finally {
      client.destroy()
    }
  }
}