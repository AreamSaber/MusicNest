import { router } from '@kit.ArkUI';
import { TopAppBar } from '../views/TopAppBar';
import { OrderCard } from '../views/OrderCard';
import { orderService } from '../service/OrderService';
import { RentalOrderVO } from '../model/Models';

/**
 * OrderList - 订单列表页
 */
@Entry
@Component
struct OrderList {
  @State orders: RentalOrderVO[] = [];
  @State activeTab: string = '';
  @State isLoading: boolean = true;

  aboutToAppear(): void { this.loadOrders(); }

  async loadOrders(): Promise<void> {
    this.isLoading = true;
    try {
      const res = await orderService.getList({ status: this.activeTab || undefined });
      if (res.data) this.orders = res.data.records;
    } catch (err) { console.error('Load orders failed'); }
    this.isLoading = false;
  }

  build() {
    Column() {
      TopAppBar({ title: '我的订单', showBack: true })

      // Tab 切换
      Row() {
        ForEach(['全部', '进行中', '已完成', '已取消'], (tab: string) => {
          Text(tab)
            .fontSize(this.activeTab === tab || (tab === '全部' && !this.activeTab) ? $r('app.float.headline_sm_font_size') : $r('app.float.body_lg_font_size'))
            .fontWeight(this.activeTab === tab || (tab === '全部' && !this.activeTab) ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.activeTab === tab || (tab === '全部' && !this.activeTab) ? $r('app.color.primary') : $r('app.color.on_surface_variant'))
            .border({ width: { bottom: this.activeTab === tab || (tab === '全部' && !this.activeTab) ? 2 : 0 }, color: $r('app.color.primary') })
            .padding({ bottom: 4 })
            .margin({ right: 24 })
            .onClick(() => {
              this.activeTab = tab === '全部' ? '' : (tab === '进行中' ? 'renting,pending,returning,overdue' : tab === '已完成' ? 'completed' : 'cancelled');
              this.loadOrders();
            })
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)

      // 列表
      if (this.isLoading) {
        Column() { LoadingProgress().width(36).height(36) }
          .width('100%').height('60%').justifyContent(FlexAlign.Center)
      } else if (this.orders.length === 0) {
        Column() {
          Text('📋').fontSize(48)
          Text('暂无订单').fontSize($r('app.float.headline_md_font_size')).margin({ top: 12 })
          Text('去租赁你心仪的乐器吧').fontSize($r('app.float.body_sm_font_size')).fontColor($r('app.color.on_surface_variant'))
        }
        .width('100%').height('60%').justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.orders, (order: RentalOrderVO) => {
            ListItem() {
              OrderCard({
                orderNo: order.orderNo,
                status: order.status,
                instrumentName: order.instrumentName,
                imageUrl: order.coverImage,
                startDate: order.startDate,
                endDate: order.endDate,
                totalAmount: order.totalAmount,
                rentDays: order.rentDays
              })
            }
            .onClick(() => {
              router.pushUrl({ url: 'pages/OrderDetail', params: { id: order.id } });
            })
          })
        }
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%').height('100%').backgroundColor($r('app.color.background'))
  }
}
