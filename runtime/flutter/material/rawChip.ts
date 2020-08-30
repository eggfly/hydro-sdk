import {Type} from "../../dart/core/type";
import {Color} from "../../dart/ui/color";
import {RuntimeBaseClass} from "../../runtimeBaseClass";
import {Widget} from "../widget";
import {CircleBorder} from "../painting/circleBorder";

import {StatelessWidget} from "./../widgets/statelessWidget";
import {Key} from "./../../flutter/foundation/key";
import {TextStyle} from "./../../flutter/painting/textStyle";
import {EdgeInsets} from "./../../flutter/painting/edgeInsets";
import {Clip} from "./../../flutter/painting/clip";
import {MaterialTapTargetSize} from "./materialTapTargetSize";
import {kDefaultDeleteIcon} from "./constants";


export interface RawChipProps {
    key?: Key | undefined;
    avatar?: Widget | undefined;
    label: Widget;
    labelStyle?: TextStyle | undefined;
    padding?: EdgeInsets | undefined;
    //visualDensity
    labelPadding?: EdgeInsets | undefined;
    deleteIcon?: Widget | undefined;
    onDeleted?: () => void | undefined;
    deleteIconColor?: Color | undefined;
    deleteButtonTooltipMessage?: string | undefined;
    onPressed?: () => void;
    onSelected?: (this: void,val: boolean) => void | undefined;
    pressElevation?: number | undefined;
    tapEnabled?: boolean | undefined;
    selected?: boolean | undefined;
    isEnabled?: boolean | undefined;
    disabledColor?: Color | undefined;
    selectedColor?: Color | undefined;
    tooltip?: string | undefined;
    //shape
    clipBehavior?: Clip | undefined;
    //focusNode
    autofocus?: boolean | undefined;
    backgroundColor?: Color | undefined;
    materialTapTargetSize?: MaterialTapTargetSize | undefined;
    elevation?: number | undefined;
    shadowColor?: Color | undefined;
    selectedShadowColor?: Color | undefined;
    showCheckmark?: boolean | undefined;
    checkmarkColor?: Color | undefined;
    avatarBorder?: CircleBorder | undefined;//this should be the base class type
}

declare const flutter: {
    material: {
        rawChip: (this: void, props: RawChipProps) => RawChip;
    };
};

export class RawChip extends StatelessWidget implements RuntimeBaseClass 
{
    public readonly internalRuntimeType = new Type(RawChip);
    public props: RawChipProps;
    public constructor(props: RawChipProps) 
    {
        super();
        this.props = props;

        if (this.props.tapEnabled === undefined) 
        {
            this.props.tapEnabled = true;
        }

        if (this.props.selected === undefined) 
        {
            this.props.selected = false;
        }

        if (this.props.isEnabled === undefined) 
        {
            this.props.isEnabled = true;
        }

        if (this.props.clipBehavior === undefined) 
        {
            this.props.clipBehavior = Clip.none;
        }

        if (this.props.autofocus === undefined) 
        {
            this.props.autofocus = false;
        }

        if (this.props.showCheckmark === undefined) 
        {
            this.props.showCheckmark = true;
        }

        if (this.props.avatarBorder === undefined) 
        {
            this.props.avatarBorder = new CircleBorder({});
        }

        if (this.props.deleteIcon === undefined) 
        {
            this.props.deleteIcon = kDefaultDeleteIcon;
        }
    }

    public build() 
    {
        return flutter.material.rawChip(this.props);
    }
}