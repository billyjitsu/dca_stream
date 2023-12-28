import Link from "next/link";
import {
  NavigationMenu,
  NavigationMenuItem,
  NavigationMenuLink,
  NavigationMenuList,
  navigationMenuTriggerStyle,
} from "~/components/ui/navigation-menu";
import { ModeToggle } from "./mode-toggle";
import { ConnectButton } from "@rainbow-me/rainbowkit";

enum NavbarOptions {
  DASHBOARD = "/app",
  WRAP = "/app/wrap",
  BRIDGE = "/app/bridge",
}

export function Navbar() {
  const navigationOptions = [
    {
      name: "Dashboard",
      href: NavbarOptions.DASHBOARD,
    },
    {
      name: "Wrap / Unwrap",
      href: NavbarOptions.WRAP,
    },
    {
      name: "Bridge",
      href: NavbarOptions.BRIDGE,
    },
  ];

  return (
    <div className="mx-auto flex items-center justify-between">
      <Link href="/">
        <div className="font-bold">Stable Bit Flow</div>
      </Link>
      <NavigationMenu>
        <NavigationMenuList>
          {navigationOptions.map((option) => (
            <NavigationMenuItem>
              <Link href={option.href} passHref>
                <NavigationMenuLink className={navigationMenuTriggerStyle()}>
                  {option.name}
                </NavigationMenuLink>
              </Link>
            </NavigationMenuItem>
          ))}
        </NavigationMenuList>
      </NavigationMenu>
      <div className="flex items-center space-x-[10px]">
        <ConnectButton />
        <ModeToggle />
      </div>
    </div>
  );
}
