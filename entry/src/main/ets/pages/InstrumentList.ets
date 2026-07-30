import { router } from '@kit.ArkUI';
import { TopAppBar } from '../views/TopAppBar';
import { InstrumentCard } from '../views/InstrumentCard';
import { instrumentService } from '../service/InstrumentService';
import { InstrumentVO } from '../model/Models';

/**
 * InstrumentList - 乐器列表页
 * 搜索 + 筛选（分类/品牌/成色/价格）+ 下拉刷新列表
 */
@Entry
@Component
struct InstrumentList {
  @State instruments: InstrumentVO[] = [];
  @State isLoading: boolean = true;
  @State keyword: string = '';
  @State activeFilter: string = '';
  @State currentPage: number = 1;

  aboutToAppear(): void {
    this.loadData();
  }

  async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      const res = await instrumentService.getList({
        page: this.currentPage,
        size: 10,
        keyword: this.keyword,
        category: this.activeFilter
      });
      if (res.data) {
        if (this.currentPage === 1) {
          this.instruments = res.data.records;
        } else {
          this.instruments = [...this.instruments, ...res.data.records];
        }
      }
    } catch (err) {
      console.error('Load instruments failed');
    }
    this.isLoading = false;
  }

  onSearch(): void {
    this.currentPage = 1;
    this.loadData();
  }

  onFilterTap(filter: string): void {
    this.activeFilter = this.activeFilter === filter ? '' : filter;
    this.currentPage = 1;
    this.loadData();
  }

  build() {
    Column() {
      TopAppBar({ title: '分类浏览', showBack: true })

      // 搜索栏
      Row() {
        TextInput({ placeholder: '搜索乐器型号、品牌...', text: this.keyword })
          .fontSize($r('app.float.body_sm_font_size'))
          .height(40)
          .borderRadius(20)
          .backgroundColor($r('app.color.surface_container_low'))
          .layoutWeight(1)
          .onChange((value: string) => {
            this.keyword = value;
          })
          .onSubmit(() => {
            this.onSearch();
          })

        Button('搜索')
          .fontSize($r('app.float.label_md_font_size'))
          .fontColor(Color.White)
          .backgroundColor($r('app.color.primary_container'))
          .borderRadius(20)
          .height(40)
          .width(56)
          .margin({ left: 8 })
          .onClick(() => this.onSearch())
      }
      .width('100%')
      .padding({ left: $r('app.float.container_padding_mobile'), right: $r('app.float.container_padding_mobile'), top: 8, bottom: 4 })

      // 筛选栏
      Row() {
        ForEach(
          ['钢琴', '吉他', '提琴', '管乐', '民乐', '打击乐'],
          (filter: string) => {
            Text(filter)
              .fontSize($r('app.float.label_md_font_size'))
              .fontColor(this.activeFilter === filter ? $r('app.color.primary') : $r('app.color.on_surface_variant'))
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderRadius(16)
              .backgroundColor(this.activeFilter === filter ? 'rgba(46,2,233,0.08)' : $r('app.color.surface_variant'))
              .margin({ right: 8 })
              .onClick(() => {
                this.onFilterTap(filter);
              })
          }
        )
      }
      .width('100%')
      .padding({ left: $r('app.float.container_padding_mobile'), right: $r('app.float.container_padding_mobile'), top: 8, bottom: 8 })
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)

      // 列表
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(36).height(36)
            .color($r('app.color.primary_container'))
            .margin({ top: 80 })
          Text('加载中...')
            .fontSize($r('app.float.body_sm_font_size'))
            .fontColor($r('app.color.on_surface_variant'))
            .margin({ top: 12 })
        }
        .width('100%').height('60%')
        .justifyContent(FlexAlign.Center)
      } else if (this.instruments.length === 0) {
        Column() {
          Text('🎵')
            .fontSize(48)
            .margin({ top: 80 })
          Text('暂无匹配乐器')
            .fontSize($r('app.float.headline_md_font_size'))
            .fontColor($r('app.color.on_surface'))
            .margin({ top: 12 })
          Text('试试其他筛选条件')
            .fontSize($r('app.float.body_sm_font_size'))
            .fontColor($r('app.color.on_surface_variant'))
        }
        .width('100%').height('60%')
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.instruments, (item: InstrumentVO) => {
            ListItem() {
              InstrumentCard({
                instrumentName: item.name,
                category: item.category,
                brand: item.brand,
                imageUrl: item.coverImage,
                monthlyPrice: item.monthlyPrice,
                rating: item.avgRating,
                status: item.status,
                conditionLevel: item.conditionLevel
              })
            }
            .onClick(() => {
              router.pushUrl({ url: 'pages/InstrumentDetail', params: { id: item.id } });
            })
          })

          ListItem() {
            Row().height(80)
          }
        }
        .layoutWeight(1)
        .padding({ left: $r('app.float.container_padding_mobile'), right: $r('app.float.container_padding_mobile') })
        .onReachEnd(() => {
          this.currentPage++;
          this.loadData();
        })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}
