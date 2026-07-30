import { router } from '@kit.ArkUI';
import { TopAppBar } from '../views/TopAppBar';
import { UserStore } from '../store/UserStore';
import { userService } from '../service/UserService';
import { UserInfo } from '../model/Models';

/**
 * Profile - 个人中心
 */
@Entry
@Component
struct Profile {
  @State userInfo: UserInfo | null = null;
  @State creditDetail: { score: number; level: number; levelLabel: string; rentCount?: number; onTimeRate?: number } | null = null;

  aboutToAppear(): void {
    this.userInfo = UserStore.getUserInfo();
    this.loadCreditScore();
  }

  async loadCreditScore(): Promise<void> {
    try {
      const res = await userService.getCreditScore();
      if (res.data) this.creditDetail = res.data;
    } catch (err) { console.error('Load credit score failed'); }
  }

  async handleLogout(): Promise<void> {
    UserStore.logout();
    router.replaceUrl({ url: 'pages/Login' });
  }

  getLevelLabel(l: number): string {
    const labels = ['', '优秀', '良好', '一般', '较差'];
    return labels[Math.min(l, 4)] || '';
  }

  build() {
    Column() {
      TopAppBar({ title: '我的', showBack: true })

      Scroll() {
        Column() {
          // 头像 + 昵称
          Column() {
            Text('👤')
              .fontSize(56)
              .width(88).height(88).borderRadius(44)
              .backgroundColor($r('app.color.surface_container_high'))
              .textAlign(TextAlign.Center)
            Text(this.userInfo?.nickname || this.userInfo?.phone || '未登录')
              .fontSize($r('app.float.headline_md_font_size')).fontWeight(FontWeight.Bold)
              .margin({ top: 12 })
            if (this.userInfo?.phone) {
              Text(this.userInfo.phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2'))
                .fontSize($r('app.float.body_sm_font_size')).fontColor($r('app.color.on_surface_variant'))
                .margin({ top: 4 })
            }
          }
          .width('100%').padding(24)
          .alignItems(HorizontalAlign.Center)

          // 信用分卡片
          Row() {
            Column() {
              Text('信用分')
                .fontSize($r('app.float.label_md_font_size')).fontColor($r('app.color.on_surface_variant'))
              Text((this.creditDetail?.score || this.userInfo?.creditScore || 600).toString())
                .fontSize(40).fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.primary'))
                .margin({ top: 4 })
              Text(this.getLevelLabel(this.creditDetail?.level || this.userInfo?.creditLevel || 2))
                .fontSize($r('app.float.body_sm_font_size')).fontColor($r('app.color.tertiary'))
                .padding({ left: 12, right: 12, top: 3, bottom: 3 })
                .borderRadius(8)
                .backgroundColor('rgba(0,83,56,0.1)')
                .margin({ top: 6 })
            }
            .alignItems(HorizontalAlign.Start)

            Blank()

            Column() {
              Text('已租次数').fontSize($r('app.float.label_sm_font_size')).fontColor($r('app.color.on_surface_variant'))
              Text((this.creditDetail?.rentCount?.toString() || '--')).fontSize($r('app.float.headline_md_font_size')).fontWeight(FontWeight.Bold).margin({ top: 4 })
              Text(this.getLevelLabel(this.creditDetail?.level || this.userInfo?.creditLevel || 2) + '信用')
                .fontSize($r('app.float.label_sm_font_size')).fontColor($r('app.color.tertiary')).margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%').padding(20).borderRadius(16)
          .backgroundColor($r('app.color.surface_container_lowest'))
          .shadow({ radius: 12, color: 'rgba(30,41,59,0.05)' })

          // 菜单列表
          Column() {
            MenuItem({ icon: '🆔', label: '实名认证', subtitle: this.userInfo?.verifyStatus === 2 ? '已认证' : '未认证', onClick: () => router.pushUrl({ url: 'pages/VerifyIdCard' }) })
            Divider().color($r('app.color.surface_variant'))
            MenuItem({ icon: '🔧', label: '报修记录', subtitle: '', onClick: () => {
              AlertDialog.show({ message: '请在订单详情页点击"报修"按钮提交报修' });
            } })
            Divider().color($r('app.color.surface_variant'))
            MenuItem({ icon: '⭐', label: '我的评价', subtitle: '', onClick: () => router.pushUrl({ url: 'pages/MyReviews' }) })
            Divider().color($r('app.color.surface_variant'))
            MenuItem({ icon: '🔔', label: '消息通知', subtitle: '3条未读', onClick: () => {
              AlertDialog.show({ message: '消息通知功能即将上线' });
            } })
            Divider().color($r('app.color.surface_variant'))
            MenuItem({ icon: '⚙️', label: '设置', subtitle: '', onClick: () => {
              AlertDialog.show({ message: '设置功能即将上线' });
            } })
          }
          .width('100%').padding(16).borderRadius(16)
          .backgroundColor($r('app.color.surface_container_lowest'))
          .shadow({ radius: 12, color: 'rgba(30,41,59,0.05)' })
          .margin({ top: 16 })

          // 退出登录
          Button('退出登录')
            .width('100%').height(48).borderRadius(14).margin({ top: 24 })
            .fontSize($r('app.float.body_md_font_size')).fontColor($r('app.color.error'))
            .backgroundColor($r('app.color.surface_container_lowest'))
            .border({ width: 1, color: $r('app.color.error_container') })
            .onClick(() => { this.handleLogout(); })

          Row().height(24)
        }
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%').backgroundColor($r('app.color.background'))
  }
}

@Component
struct MenuItem {
  @Prop icon: string = '';
  @Prop label: string = '';
  @Prop subtitle: string = '';
  onClick?: () => void;

  build() {
    Row() {
      Text(this.icon).fontSize(20)
      Text(this.label).fontSize($r('app.float.body_md_font_size')).margin({ left: 12 })
      Blank()
      if (this.subtitle) Text(this.subtitle).fontSize($r('app.float.body_sm_font_size')).fontColor($r('app.color.on_surface_variant')).margin({ right: 4 })
      Text('›').fontSize(20).fontColor($r('app.color.outline'))
    }
    .width('100%').padding({ top: 14, bottom: 14 })
    .onClick(() => { if (this.onClick) this.onClick(); })
  }
}
