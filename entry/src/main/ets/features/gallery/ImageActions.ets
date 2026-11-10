import { common } from '@kit.AbilityKit'
import { systemShare } from '@kit.ShareKit'
import { uniformTypeDescriptor as utd } from '@kit.ArkData'
import { picker, fileIo } from '@kit.CoreFileKit'
import { http } from '@kit.NetworkKit'
import { ImageItem } from '../../model/ImageItem'

/** Platform operations used by the gallery; the view owns presentation and feedback. */
export class ImageActions {
  static async share(context: common.UIAbilityContext, item: ImageItem): Promise<void> {
    const data = new systemShare.SharedData({
      utd: utd.UniformDataType.PLAIN_TEXT, content: item.imageUrl, title: item.title || item.source
    })
    const controller = new systemShare.ShareController(data)
    await controller.show(context, {})
  }

  static async openOriginal(context: common.UIAbilityContext, item: ImageItem): Promise<void> {
    await context.startAbility({ action: 'ohos.want.action.viewData', uri: item.imageUrl })
  }

  /** Returns false when the user cancels the save picker. */
  static async save(context: common.UIAbilityContext, item: ImageItem): Promise<boolean> {
    const client = http.createHttp()
    try {
      const response = await client.request(item.imageUrl, {
        method: http.RequestMethod.GET, expectDataType: http.HttpDataType.ARRAY_BUFFER,
        connectTimeout: 15000, readTimeout: 30000
      })
      if (response.responseCode !== 200 || !(response.result instanceof ArrayBuffer)) throw new Error('download failed')
      const match = item.imageUrl.split('?')[0].match(/\.(jpg|jpeg|png|webp|gif)$/i)
      const suffix = match ? match[1].toLowerCase() : 'bin'
      const options = new picker.DocumentSaveOptions()
      options.newFileNames = [`AnimeLens-${Date.now()}.${suffix}`]
      const selector = new picker.DocumentViewPicker(context)
      const uris = await selector.save(options)
      if (uris.length === 0) return false
      const file = fileIo.openSync(uris[0], fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.TRUNC)
      try {
        const bytes = response.result as ArrayBuffer
        const written = await fileIo.write(file.fd, bytes)
        if (written !== bytes.byteLength) throw new Error('incomplete write')
      } finally { fileIo.closeSync(file) }
      return true
    } finally {
      client.destroy()
    }
  }
}
