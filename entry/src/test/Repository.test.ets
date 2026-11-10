import { describe, it, expect } from '@ohos/hypium'
import { ImageRepository } from '../main/ets/service/ImageRepository'
import { IImageService } from '../main/ets/service/IImageService'
import { ImageItem } from '../main/ets/model/ImageItem'
import { ConnectionStatus, SourceType } from '../main/ets/model/SourceConfig'

class RepositoryTestService implements IImageService {
  public lastPage: number = 0
  public lastFilter: boolean = false
  public failTest: boolean = false

  async load(page: number, nsfwEnabled: boolean): Promise<ImageItem[]> {
    this.lastPage = page
    this.lastFilter = nsfwEnabled
    return []
  }

  async testConnection(nsfwEnabled: boolean): Promise<number> {
    this.lastFilter = nsfwEnabled
    if (this.failTest) throw new Error('test failure')
    return 25
  }
}

export default function repositoryTest() {
  describe('ImageRepository', () => {
    it('keepsConfigSnapshotsPrivate', 0, () => {
      const services = new Map<SourceType, IImageService>()
      const repo = new ImageRepository(services)
      const configs = repo.getConfigs()
      configs[0].isEnabled = false
      expect(repo.getConfigs()[0].isEnabled).assertTrue()
      repo.setSourceEnabled(SourceType.PICSUM, false)
      expect(repo.getConfigs()[0].isEnabled).assertFalse()
    })
    it('sendsSourceAndFilterToTheSelectedProvider', 0, async () => {
      const first = new RepositoryTestService()
      const second = new RepositoryTestService()
      const services = new Map<SourceType, IImageService>()
      services.set(SourceType.PICSUM, first)
      services.set(SourceType.KONACHAN, second)
      const repo = new ImageRepository(services)
      repo.setNsfwEnabled(true)
      await repo.load(SourceType.KONACHAN, 3)
      expect(first.lastPage).assertEqual(0)
      expect(second.lastPage).assertEqual(3)
      expect(second.lastFilter).assertTrue()
      expect(repo.getFilterRevision()).assertEqual(1)
      repo.setNsfwEnabled(true)
      expect(repo.getFilterRevision()).assertEqual(1)
      repo.setNsfwEnabled(false)
      expect(repo.getFilterRevision()).assertEqual(2)
    })
    it('reportsFailedConnectionTests', 0, async () => {
      const service = new RepositoryTestService()
      service.failTest = true
      const services = new Map<SourceType, IImageService>()
      services.set(SourceType.PICSUM, service)
      const repo = new ImageRepository(services)
      await repo.testSource(SourceType.PICSUM)
      expect(repo.getConfigs()[0].status).assertEqual(ConnectionStatus.FAILED)
    })
  })
}
