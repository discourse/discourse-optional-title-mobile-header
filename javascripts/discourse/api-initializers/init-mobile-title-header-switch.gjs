import { action } from "@ember/object";
import PreferenceCheckbox from "discourse/components/preference-checkbox";
import { apiInitializer } from "discourse/lib/api";

function getMobileSwitchTitle() {
  let pref = localStorage.getItem("mobileSwitchTitle");
  let result = settings.default_enabled;
  if (pref !== null) {
    result = pref === "true";
  }
  return result;
}

export default apiInitializer("0.8", (api) => {
  if (!api.container.lookup("service:site").mobileView) {
    return;
  }

  if (!getMobileSwitchTitle()) {
    api.modifyClass(
      "service:header",
      (Superclass) =>
        class extends Superclass {
          get topicInfoVisible() {
            return false;
          }
        }
    );
  }

  api.getCurrentUser().mobileSwitchTitle = getMobileSwitchTitle();

  api.modifyClass(
    "controller:preferences/interface",
    (Superclass) =>
      class extends Superclass {
        @action
        save() {
          (super.save || super.actions.save.bind(this))();
          if (getMobileSwitchTitle() !== this.get("model.mobileSwitchTitle")) {
            this.session.requiresRefresh = true;
          }
          localStorage.setItem(
            "mobileSwitchTitle",
            this.get("model.mobileSwitchTitle").toString()
          );
        }
      }
  );

  api.renderInOutlet(
    "user-preferences-interface",
    <template>
      <PreferenceCheckbox
        @labelKey={{themePrefix "mobile_switch_title"}}
        @checked={{@outletArgs.model.mobileSwitchTitle}}
      />
    </template>
  );
});
