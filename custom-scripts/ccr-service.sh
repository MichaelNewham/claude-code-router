#!/bin/bash
#
# ccr-service.sh - Manage CCR systemd service
# Quick commands for CCR service management
#

case "${1:-}" in
    status)
        systemctl status ccr.service
        ;;
    start)
        systemctl start ccr.service
        ;;
    stop)
        systemctl stop ccr.service
        ;;
    restart)
        echo "Restarting CCR service..."
        systemctl restart ccr.service
        sleep 2
        systemctl status ccr.service
        ;;
    logs)
        journalctl -u ccr.service -f
        ;;
    enable)
        systemctl enable ccr.service
        echo "CCR will start on boot"
        ;;
    disable)
        systemctl disable ccr.service
        echo "CCR will NOT start on boot"
        ;;
    *)
        echo "Usage: ccr-service.sh {status|start|stop|restart|logs|enable|disable}"
        echo ""
        echo "Commands:"
        echo "  status   - Show service status"
        echo "  start    - Start service"
        echo "  stop     - Stop service"
        echo "  restart  - Restart service (use after config changes)"
        echo "  logs     - Watch live logs"
        echo "  enable   - Enable auto-start on boot"
        echo "  disable  - Disable auto-start"
        echo ""
        echo "Quick access:"
        echo "  systemctl status ccr"
        echo "  systemctl restart ccr"
        echo "  journalctl -u ccr -f"
        exit 1
        ;;
esac
