package store

import (
	"github.com/squaremo/ambergreen/common/data"
)

type ServiceFunc func(string, data.Service)
type InstanceFunc func(string, data.Instance)
type ServiceInstanceFunc func(string, string, data.Instance)

type Store interface {
	Ping() error
	CheckRegisteredService(serviceName string) error
	AddService(serviceName string, details data.Service) error
	RemoveService(serviceName string) error
	RemoveAllServices() error
	GetServiceDetails(serviceName string) (data.Service, error)
	ForeachServiceInstance(fs ServiceFunc, fi ServiceInstanceFunc) error
	AddInstance(serviceName string, instanceName string, details data.Instance) error
	RemoveInstance(serviceName, instanceName string) error
	ForeachInstance(serviceName string, fi InstanceFunc) error
	WatchServices(resCh chan<- data.ServiceChange, stopCh <-chan struct{}, withInstanceChanges bool)
}
