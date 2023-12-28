import { Github, MessageCircle, Twitter, Youtube } from "lucide-react";
import Link from "next/link";
import {
  NavigationMenu,
  NavigationMenuItem,
  NavigationMenuLink,
  NavigationMenuList,
  navigationMenuTriggerStyle,
} from "~/components/ui/navigation-menu";

export function Footer() {
  const quickNavigationOptions = [
    {
      name: "X",
      href: "https://www.x.com",
      icon: Twitter,
    },
    {
      name: "GitHub",
      href: "https://www.github.com",
      icon: Github,
    },
    {
      name: "Telegram",
      href: "https://telegram.com",
      icon: MessageCircle,
    },
    {
      name: "YouTube",
      href: "https://youtube.com",
      icon: Youtube,
    },
  ];

  return (
    <div className="flex items-center justify-between py-4">
      <div className="text-[13px] opacity-60">
        &copy; {new Date().getFullYear()} StableBitFlow, Inc.
      </div>
      <NavigationMenu>
        <NavigationMenuList>
          {quickNavigationOptions.map((option) => (
            <NavigationMenuItem key={option.name}>
              <Link href={option.href} passHref>
                <NavigationMenuLink className={navigationMenuTriggerStyle()}>
                  <option.icon
                    className="opacity-60 hover:opacity-100"
                    size={18}
                  />
                </NavigationMenuLink>
              </Link>
            </NavigationMenuItem>
          ))}
        </NavigationMenuList>
      </NavigationMenu>
    </div>
  );
}
