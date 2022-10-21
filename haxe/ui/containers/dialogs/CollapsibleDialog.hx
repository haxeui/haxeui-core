package haxe.ui.containers.dialogs;

import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.events.MouseEvent;

/**
 * A dialog with a minimize/maximize button in the title bar, which collapses the dialog body.
 */
class CollapsibleDialog extends Dialog
{
	public var dialogMinMaxButton:haxe.ui.components.Image;

  /**
   * Set this property to collapse/expand the dialog body.
   */
	public var minimized(default, set):Bool = false;

  function set_minimized(value:Bool):Bool {
    if (value == this.minimized) return value;

    if (value)
      minimize();
    else
      maximize();

    return this.minimized = value;
  }

	public function new() {
		super();

    // Create the minimize/maximize button.
		dialogMinMaxButton = new haxe.ui.components.Image();
		dialogMinMaxButton.id = "dialog-minmax-button";
		dialogMinMaxButton.styleNames = "dialog-minimize-button";
		dialogTitle.addComponent(dialogMinMaxButton);

		// Move the button before the close button
		dialogTitle.setComponentIndex(dialogMinMaxButton, 1);
	}

  @:bind(dialogMinMaxButton, MouseEvent.CLICK)
  private function onMinMax(_) {
    minimized = !minimized;
  }

  /**
   * This function is private. Call dialog.minimized = true instead.
   */
  private function minimize() {
		// Switch the button appearance.
		dialogMinMaxButton.swapClass("dialog-maximize-button", "dialog-minimize-button");

		// Collapse the dialog.
		dialogContent.hidden = true;
		this.height -= dialogContent.height;
  }

  /**
   * This function is private. Call dialog.minimized = false instead.
   */
	private function maximize() {
		// Switch the button appearance.
		dialogMinMaxButton.swapClass("dialog-minimize-button", "dialog-maximize-button");

		// Uncollapse the dialog.
		dialogContent.hidden = false;
		this.height += dialogContent.height;
	}
}
